import 'package:app/src/lazy.dart';
import 'package:app/src/models/person_models.dart';
import 'package:app/src/resources/firebase_provider.dart';
import 'package:app/src/vm/vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Doc {
  final String path;

  Doc(this.path);
}

class Personalized extends Doc {
  final String personPath;

  late final Lazy<Observable<Person?>> person;

  Personalized(String path, this.personPath) : super(path) {
    person = Lazy(() => FirebaseProvider.person(personPath).toObservable(null));
  }
}

class Reactionable extends Personalized {
  late final Lazy<Observable<Availability>> availability;
  late final Lazy<Observable<int>> reactionCount;

  Reactionable(String path, String personPath) : super(path, personPath) {
    availability = Lazy(() => FirebaseProvider.isReactionAvailable(this)
        .toObservable(Availability.owner));
    reactionCount =
        Lazy(() => FirebaseProvider.reactionCount(this).toObservable(0));
  }
}

enum Availability {
  not_acted,
  acted,
  owner,
}

class Question extends Reactionable {
  // should handle links on shares
  final String content;
  final List<dynamic> tickers;

  Question(String path, String personPath, this.content, this.tickers)
      : super(path, personPath);

  Question.create(String personPath, this.content, this.tickers)
      : super('', personPath);

  factory Question.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Question(
      snapshot.reference.path,
      (json['person'] as DocumentReference?)?.path ?? '',
      json['content'] as String? ?? '',
      json['tickers'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'person': FirebaseFirestore.instance.doc(personPath),
        'content': content,
        'tickers': tickers,
        'created_at': Timestamp.now(),
      };
}

class Answer extends Reactionable {
  final String personPath;
  // should handle links on shares
  final String content;
  final bool accepted;
  final List<dynamic> tickers;

  Answer(
      String path, this.personPath, this.content, this.accepted, this.tickers)
      : super(path, personPath);

  Answer.create(this.personPath, this.content, this.tickers)
      : accepted = false,
        super('', personPath);

  factory Answer.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Answer(
      snapshot.reference.path,
      (json['person'] as DocumentReference?)?.path ?? '',
      json['content'] as String? ?? '',
      json['accepted'] as bool? ?? false,
      json['tickers'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'person': FirebaseFirestore.instance.doc(personPath),
        'content': content,
        'tickers': tickers,
        'accepted': accepted,
        'created_at': Timestamp.now(),
      };
}

class Reaction extends Personalized {
  Reaction(String path, String personPath) : super(path, personPath);

  Reaction.create(String personPath) : super('', personPath);

  factory Reaction.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Reaction(
      snapshot.reference.path,
      (json['person'] as DocumentReference?)?.path ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'person': FirebaseFirestore.instance.doc(personPath),
        'created_at': Timestamp.now(),
      };
}

class Event {
  final String id;
  final String name;
  final String icon;
  final String content;
  final int conditions;
  final int award;
  final String link;

  Event(
      this.id, this.name, this.icon, this.content, this.conditions, this.award,
      {this.link = ''});
}

class Level {
  final int number;
  final String name;
  final List<String> events;

  Level(this.number, this.name, this.events);
}
