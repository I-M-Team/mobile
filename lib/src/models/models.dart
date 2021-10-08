import 'package:app/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Doc {
  final String path;

  Doc(this.path);
}

class Personalized extends Doc {
  final String personPath;

  Personalized(String path, this.personPath) : super(path);
}

class Question extends Personalized {
  // should handle links on shares
  final String content;

  Question(String path, String personPath, this.content)
      : super(path, personPath);

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
  Reaction({String? path, required String personPath})
      : super(path.orDefault(), personPath);

  factory Reaction.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var json = snapshot.data()!;
    return Reaction(
      path: snapshot.reference.path,
      personPath: (json['person'] as DocumentReference?)?.path ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'person': FirebaseFirestore.instance.doc(personPath),
        'created_at': Timestamp.now(),
      };
}
