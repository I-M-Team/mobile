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

class Question extends Personalized {
  // should handle links on shares
  final String content;

  Question(String path, String personPath, this.content)
      : super(path, personPath);

  Question.create(String personPath, this.content) : super('', personPath);

  factory Question.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Question(
      snapshot.reference.path,
      (json['person'] as DocumentReference?)?.path ?? '',
      json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'person': FirebaseFirestore.instance.doc(personPath),
        'content': content,
        'created_at': Timestamp.now(),
      };
}

class Answer extends Personalized {
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
