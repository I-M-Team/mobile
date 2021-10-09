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

  Reactionable(String path, String personPath) : super(path, personPath) {
    availability = Lazy(() => FirebaseProvider.isReactionAvailable(this)
        .toObservable(Availability.unavailable));
  }
}

enum Availability {
  available,
  available_negation,
  unavailable,
}

class Question extends Reactionable {
  // should handle links on shares
  final String content;
  final List<dynamic> tickers;

  Question(String path, String personPath, this.content, this.tickers)
      : super(path, personPath);

  Question.create(String personPath, this.content, this.tickers) : super('', personPath);

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

  Answer(String path, this.personPath, this.content, this.accepted)
      : super(path, personPath);

  Answer.create(this.personPath, this.content)
      : accepted = false,
        super('', personPath);

  factory Answer.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Answer(
      snapshot.reference.path,
      (json['person'] as DocumentReference?)?.path ?? '',
      json['content'] as String? ?? '',
      json['accepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'person': FirebaseFirestore.instance.doc(personPath),
        'content': content,
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
